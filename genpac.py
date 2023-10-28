import re

def parse_domian(file):
    element_list = open('domain-list-community/data/' + file).read().split()
    for i in element_list:
            if re.match('[\w.-]+\.\w+$', i, re.A):
                    domain_list.append(i)
            elif re.match('include:(\S+)', i):
                    parse_domian(re.match('include:(\S+)', i).group(1))

domain_list = []
parse_domian('geolocation-!cn')
domain_list.sort()
domain_string = "',\n\t'".join(domain_list)

def genpac(port):
    pac = f'''var proxy = 'SOCKS5 127.0.0.1:{port}; DIRECT';
var rules = [
    '{domain_string}'
]

'''
    pac += '''function FindProxyForURL(url, host) {
if (rules.includes(/[^.]\.(.+)/.exec(host)[1]) || rules.includes(host)) {
 return proxy;
}
}'''
    open(str(port) + '.pac', 'w').write(pac)

genpac(7890)
genpac(9001)
