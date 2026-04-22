terraform {
  backend "s3" {
    bucket       = "karasuit"
    key          = "snowflake.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
