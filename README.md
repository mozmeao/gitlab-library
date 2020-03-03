# gitlab-library

A repository to story a set of extendable/modular pipeline pieces. (in some ideal world, testing and examples to go along with it)


# Usage

### Terraform

We're making a ton of assumptions about how terraform works for you in this pipeline definition.  Among them are:

- single workspace defined (implicit 'default')
- remote state configured
- two variables to change behavior, to override you can either add a variable block to a specific job OR make a .base_#{thing} job. Make sure to list the most specific extend job last to get the merge correct.
  - tf_version: "0.12.20" (may change, but generally will be kept on 'latest')
  - subdir: "." (this should be the path to the 'context' of the terraform you want to run.  Modules can be a subdirectory from there, but the main.tf file should be in this dir relative to where gitlab is running)

For remote state, add this block to any .tf file in the directory you're intending to apply.  This will store the state remotely to keep terraform up to date no matter which computer it's running on.

```
terraform {
  backend "s3" {
    bucket  = "#{Bucketname}"
    key     = "#{tfkey}"  # This allow multiple tfs to share a bucket
    region  = "#{bucket_region}"
    encrypt = true
  }
}
```
##### To make available to use
```
include:
  - remote: "https://raw.githubusercontent.com/mozmeao/gitlab-library/master/terraform.yml"
```
then write one or many jobs that have extends for the job below.  script section won't be merged, so if you want both what we've provided here and more use before_script or after_script


You'll likely want to define a resource_group, that all of your jobs share.  That acts as a state lock to prevent multiple jobs in a pipeline from running at the same time and killing each other.  Recommendation would be to name this group after your service, for example velero for the velero pipeline.

##### Jobs
.terraform_validate runs tf init and tf validate.  needs enough creds to get to s3 bucket if state is in that bucket.
.terraform_plan runs tf init/tf plan then creates artifacts of the plan file and the needed context (.terraform) dir
.terraform_apply tf apply from the plan file, which is an implicit auto approve


### Ingress

Used for generating a yaml file to deploy an voyager ingress configuration.  Goal is to make it so multiple branches can share a single alb.

.combined-ingress, this does the whole thing.  You just need to choose the values. Used in bedrock if you want an example.  Also in this repo's gitlab-ci.yml file.  (this part is a little sparse intentionally, since we on;y have a single use case it may make since for a second one to come along before working on it too much.)

override any/all of these settings.
    version: 0.0.9
    image: mozmeao/combinedingress
    GIT_STRATEGY: clone
    port: 80
    dns_prefix: ''
    git_prefix: 'demo/'
    service: library
    domain: mozmar.org
    staging: --from-literal=ACME_SERVER_URL=https://acme-staging-v02.api.letsencrypt.org/directory

