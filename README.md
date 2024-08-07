# BaRecon
BaRecon is a Bash-based tool that performs basic reconnaissance on a network block, a domain and its subdomains, or a single IP address.

All dependencies are automatically installed when the tool is executed.

Root permissions are required to use the tool.

Features
---

The features of this tool include:
- ### Network block scanning
  - Network address
  - Network owner
  - Country
  - Total hosts
  - First and last IP address
  - Scanning hosts
    - IP
    - Associated hostnames
    - Ping response
    - Open ports
    - HTTP responses
- ### Domain scanning
  - Subdomain scanning
    - Subdomain
    - IP
    - Network owner
    - Country
    - Ping response
    - Open ports
    - HTTP responses
- ### IP address scanning
  - Network owner
  - Associated hostnames
  - Ping response
  - Open ports
  - HTTP responses
- ### Automatic saving of results to text files

Installation 
---

```bash
wget https://raw.githubusercontent.com/Tomas-Ortiz/barecon/main/BaRecon.sh
```

```bash
chmod +x BaRecon.sh
```

```bash
sudo su
```

Usage
---

#### Help panel

```bash
./BaRecon.sh -h
```


<img src="https://github.com/user-attachments/assets/7d9a8469-afd4-4fe3-830d-ab7a3438d58d" style="width: 100%; height: auto;" />


#### Scanning a network block

```bash
./BasicRecon.sh -n <CIDR>
```

<img src="https://github.com/user-attachments/assets/6b3585ab-33ae-4cb5-96ed-07e03dd3ef34" style="width: 100%; height: auto;" />

<img src="https://github.com/user-attachments/assets/fe6db4da-4b05-4b1d-a518-b2c57c034e86" style="width: 100%; height: auto;" />

<img src="https://github.com/user-attachments/assets/f51ffb6a-07da-4725-a50c-355e2c23ea2a" style="width: 100%; height: auto;" />


#### Scanning a domain and its subdomains

```bash
./BasicRecon.sh -d <DOMAIN>
```


<img src="https://github.com/user-attachments/assets/323974fe-37b4-429f-a211-910189f0d1b2" style="width: 100%; height: auto;" />

<img src="https://github.com/user-attachments/assets/2dc19f4d-db79-42a8-a0bf-ebe74a611893" style="width: 100%; height: auto;" />

<img src="https://github.com/user-attachments/assets/475af4a6-5ecf-42e2-99fa-7df817207f82" style="width: 100%; height: auto;" />


#### Scanning a single IP

```bash
./BasicRecon.sh -a <IP>
```


<img src="https://github.com/user-attachments/assets/050e99c8-9777-48cf-a024-aca77aba36f2" style="width: 100%; height: auto;" />
