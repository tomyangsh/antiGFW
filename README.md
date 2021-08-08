# 搭梯教程

需要一台服务器 可以上vultr买日本$5的，如果vultr上不去，在 hosts 文件里加一行：

    1.1.1.1 www.vultr.com

系统请选Debian

需要一个域名，可以去 [freenom](https://www.freenom.com/) 白嫖一个，根据 [教程](https://zhujitips.com/328) 取得域名并注册cloudflare

进Cloudflare控制台（右上角可切换至简体中文），点进DNS，设置好根域名后，增加一个二级域名。
点添加记录, 类型默认A, 名称填一个长一点的，比如 dontyoufxxkwithme , ip填vps的ip
点上方SSL/TLS，加密模式改成完全（严格）
点进源服务器，点创建证书，下一步，此时能看到两大串密文，上面是证书，下方是密钥，分别复制并保存下来，注意从最开头-----开始复制

用putty等工具通过ssh登入vps，首先执行

    nano ssl.crt

粘贴刚复制的第一段证书部分，按F3保存，回车确认后按F2退出编辑，然后执行

    nano ssl.key

粘贴刚复制的第二段密钥部分，按F3保存，回车确认后按F2退出编辑

执行

    bash -c "$(wget -O - https://github.com/tomyangsh/antiGFW/raw/master/trojan-install.sh)"

或

    bash -c "$(curl -sL https://github.com/tomyangsh/antiGFW/raw/master/trojan-install.sh)"

按提示输入之前创建的二级域名，如 dontyoufxxkwithme.xxxxx.tk 并输入密码
执行完成后会有提示服务是否成功运行（如果是Debian 9，需要 [手动开启BBR](https://www.mf8.biz/debian9-bbr/)），然后便可Ctrl+D退出ssh

至此 vps上直连的trojan和走cdn的trojan-go都已部署完成

使用 [此工具](https://github.com/XIU2/CloudflareSpeedTest/releases/download/v1.4.8/CloudflareST_windows_amd64.zip) 找出最快的cf节点，在 C:\Windows\System32\drivers\etc\hosts 给自己的域名加一行，例如：

    104.23.96.150 dontyoufxxkwithme.xxxxx.tk

根据 <https://qv2ray.net/getting-started/step2.html> 装好qv2ray并配置核心，按照 <https://qv2ray.net/plugins/usage.html> 启用下面两个插件

<https://github.com/Qv2ray/QvPlugin-Trojan>

<https://github.com/Qv2ray/QvPlugin-Trojan-Go>

注意trojan-go要手动下载并指定核心，参见

<https://www.jamesdailylife.com/qv2ray>

新建链接-手动输入，这里要创建两个
1. 主机填vps的ip，端口443，类型选Trojan，password先之前创建的密码，SNI填之前创建的二级域名，如 dontyoufxxkwithme.xxxxx.tk ，勾选下方Ignore Certificate和Ignore Host，ok确认
2. 主机填域名，端口8443，类型选Trojan-Go，password先之前创建的密码，SNI填域名，勾选Mux，Type选ws，Host填域名，Path填`/alonglonglongwebsocketpath`，ok确认

关于路由规则，可以自己研究路由规则，或使用下方pac自动配置文件（对应socks5端口为1089）。设置前先在 hosts 文件中添加一行 `199.232.36.133 raw.githubusercontent.com` 以防DNS污染。

    https://github.com/tomyangsh/antiGFW/raw/master/1089.pac

在 Windows 系统中，通过「Internet选项->连接->局域网设置-> 使用自动配置脚本」可以找到配置处，下方的地址栏填写 PAC 文件地址
Chrome 中可以在「chrome://settings/->显示高级设置->更改代理服务器设置」中找到 PAC 填写地址。

若想在整个局域网内共享，可在qv2ray“入站设置”中把监听地址改为 0.0.0.0 ，下载上方的pac文件，将其中的ip地址127.0.0.1更改为本机的局域网ip地址，如 192.168.0.20 （请设置固定ip），使用nginx等搭建http服务器，手机等其他设备填写相应地址即可，如 `http://192.168.0.20/proxy.pac` 。
