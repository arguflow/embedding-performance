# hi

This is meant to test the tps and ... of embedding servers
Using terraform only for the purpose of reproducability, and is 

## Setup terraform

Download terraform cli
Download aws cli

run `aws configure` You will see a prompt similar to this

```
user@machine $ aws configure
AWS Access Key ID [****************PYVK]: ****PYVK
AWS Secret Access Key [****************duMt]: ****duMt
Default region name [eu-central-1]: 
Default output format [None]: 

user@machine $
```

To get the ACCESS KEY and SECRET KEY you must create a user, give that user
admin perms and request for an access key for cli usage. The begining of this
guide here worked for me. https://spacelift.io/blog/terraform-tutorial

## Reproduce tests

```sh
terraform init
cp <your-ssh-pub-key-location> ./ssh-key.pub
terraform apply
```

You should see this as your output

```
side_car_ip = "<your-side_car-ip>"
splade_ip = "<your-splade-server-ip>"
```

The side_car_ip is what we will test from

```sh
ssh dev@<your-side_car-ip>
./test.sh <your-splade-server-ip>
./test.sh <your-embedding-server-ip>
```

To change the machine type 
```
update the server-machine-type
```

To bring down all servers 

```
terraform destroy
```
