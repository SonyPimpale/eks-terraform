# eks-terraform

## Terraform Initialse
terraform init

## Terraform Plan using variable file and storing output into text file.
  terraform plan --var-file=<filename>
  Example : terraform plan --var-file=dev.tfvars
  terraform plan --var-file=dev.tfvars -out output.txt (Storing output into text file)

## Terraform apply storing the output into text file
terraform apply "<Text file name>
Example : terraform apply "output.txt"

## Terraform Destroy using variable file
terraform destroy -var-file=<filename>
terraform destroy -var-file=dev.tfvars 

  