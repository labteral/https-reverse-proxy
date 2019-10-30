#!/usr/bin/env python
# -*- coding: utf-8 -*-

import yaml
import os

TAB = ' ' * 4


def load_haproxy_conf():
    with open('haproxy.yaml', 'r') as yaml_file:
        return yaml.load(yaml_file)


def load_domains_conf():
    with open('domains.yaml', 'r') as yaml_file:
        conf = yaml.load(yaml_file)
        for key, value in conf.items():
            if 'endpoints' not in value:
                value['endpoints'] = []
            if 'ssl_endpoints' not in value:
                value['ssl_endpoints'] = []
        return conf


def get_inbound_template():
    return {
        'frontend inbound': {
            'bind': ['*:80', '*:443 ssl crt /etc/haproxy/ssl'],
            'reqadd': 'X-Forwarded-Proto:\\ https',
            'acl': [],
            'redirect': None,
            'use_backend': []
        }
    }


def should_print_empty_line(key, value, already_printed):
    if len(value) > 1 and key not in ['option', 'server'] and not already_printed:
        return True
    return False


def dump_haproxy_conf(haproxy_conf):
    with open('/etc/haproxy/haproxy.cfg', 'w') as output_file:
        for key, value in haproxy_conf.items():
            output_file.write(f'{key}\n')
            already_printed = False
            for key2, value2 in value.items():
                if type(value2) == dict:
                    for key3, value3 in value2.items():
                        output_file.write(f'{TAB}{key2} {key3} {value3}\n')
                    already_printed = False
                    continue
                elif type(value2) == list:
                    if should_print_empty_line(key2, value2, already_printed):
                        output_file.write('\n')
                    for value3 in value2:
                        output_file.write(f'{TAB}{key2} {value3}\n')
                    if should_print_empty_line(key2, value2, False):
                        output_file.write('\n')
                    already_printed = True
                    continue
                if value2:
                    output_file.write(f'{TAB}{key2} {value2}\n')
                    already_printed = False
                    continue
                output_file.write(f'{TAB}{key2}\n')
                already_printed = False
            output_file.write('\n')


def update_haproxy_conf_with_domains(haproxy_conf, domains_conf):
    inbound_template = get_inbound_template()
    non_ssl_domains = []
    for i, kv in enumerate(domains_conf.items()):
        key, value = kv
        domains_string = ' '.join([f'-i {domain}' for domain in value['domains']])
        inbound_template['frontend inbound']['acl'].append(f'is_domain{i} hdr(host) {domains_string}')
        
        if 'ssl' in value and not value['ssl']:
            non_ssl_domains.append(i)
        inbound_template['frontend inbound']['use_backend'].append(f'domain{i} if is_domain{i}')
        
        server_lines = []

        if 'endpoints' in value:
            check_string = ''
            if len(value['endpoints']) > 1:
                check_string = 'check '
            for j, endpoint in enumerate(value['endpoints']):
                server_lines.append(f"s{i}{j} {endpoint} {check_string}maxconn {haproxy_conf['global']['maxconn']}")

        if 'ssl_endpoints' in value:
            ssl_check_string = ''
            if len(value['ssl_endpoints']) > 1:
                ssl_check_string = 'check '
            for j, ssl_endpoint in enumerate(value['ssl_endpoints']):
                server_lines.append(
                    f"s{i}{j} {ssl_endpoint} {ssl_check_string}ssl verify none maxconn {haproxy_conf['global']['maxconn']}"
                )

        inbound_template[f'backend domain{i} # {key}'] = {
            'balance': 'roundrobin',
            'option': ['httpclose', 'forwardfor'],
            'server': server_lines
        }
    neg_string = ' '.join([f'!is_domain{i}' for i in non_ssl_domains])
    inbound_template['frontend inbound']['redirect'] = f"scheme https code 301 if {neg_string} !{{ ssl_fc }}"
    haproxy_conf.update(inbound_template)


def dump_certbot_script(domains_conf):
    domains = []
    for _, value in domains_conf.items():
        domains += value['domains']

    with open('get-certs.sh', 'a') as output_file:
        output_file.write('#!/bin/bash\n')
        certonly_base_cmd = f"certbot certonly --non-interactive --keep --expand --agree-tos -m {os.environ['LETSENCRYPT_EMAIL']} --standalone -d"
        for domain in domains:
            output_file.write(
                f'{certonly_base_cmd} {domain} && cat /etc/letsencrypt/live/{domain}/fullchain.pem /etc/letsencrypt/live/{domain}/privkey.pem > /etc/haproxy/ssl/{domain}.pem\n'
            )


if __name__ == "__main__":
    haproxy_conf = load_haproxy_conf()
    domains_conf = load_domains_conf()
    update_haproxy_conf_with_domains(haproxy_conf, domains_conf)
    dump_haproxy_conf(haproxy_conf)
    dump_certbot_script(domains_conf)
