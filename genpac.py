import re

def gen_list(file):
    domain_list = []
    element_list = open(f"domain-list-community/{file}.txt").read().split()

    for i in element_list:
        parse = re.match('(domain|full):([\w.-]+\.\w+)$', i, re.A)
        if parse:
            domain_list.append(parse.group(2))

    domain_list.sort()
    return domain_list

def gen_pac(rule, domain_list, name):
    domain_str = "',\n\t'".join(domain_list)
    pac = f'''var rule = '{rule}';
var domain_list = [
\t'{domain_str}'
]

'''
    pac += '''function FindProxyForURL(url, host) {
    if (domain_list.includes(host.match(/\.(.+)/)[1]) || domain_list.includes(host)) {
        return rule;
    }
}'''
    open(str(name) + '.pac', 'w').write(pac)

foreign_list = gen_list('geolocation-!cn')

gen_pac('SOCKS5 127.0.0.1:7890', foreign_list, 7890)
gen_pac('SOCKS5 127.0.0.1:9001; SOCKS5 192.168.50.10:9001; SOCKS5 192.168.50.10:9002; SOCKS5 192.168.50.10:9003; SOCKS5 192.168.50.10:9004', foreign_list, 9001)

cn_list = [
        'i.duan.red',
        'l.qq.com'
        ]
cn_list += gen_list('cn')

gen_pac('SOCKS5 127.0.0.1:1080; DIRECT', cn_list, 'cn')
