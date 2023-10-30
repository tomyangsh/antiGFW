import re

def genpac(port, name='', file='geolocation-!cn', custom_list=[], host='127.0.0.1'):
    domain_list = custom_list[:]
    element_list = open(f"domain-list-community/{file}.txt").read().split()

    for i in element_list:
        parse = re.match('(domain|full):([\w.-]+\.\w+)$', i, re.A)
        if parse:
            domain_list.append(parse.group(2))

    domain_list.sort()
    domain_string = "',\n\t'".join(domain_list)

    pac = f'''var proxy = 'SOCKS5 {host}:{port}; DIRECT';
var rules = [
\t'{domain_string}'
]

'''
    pac += '''function FindProxyForURL(url, host) {
    if (rules.includes(host.match(/\.(.+)/)[1]) || rules.includes(host)) {
        return proxy;
    }
}'''
    open(str(name or port) + '.pac', 'w').write(pac)

genpac(7890)
genpac(9001)

cn_list = [
        'i.duan.red',
        'l.qq.com'
        ]

genpac(9001, name='cn', file='cn', custom_list=cn_list)
