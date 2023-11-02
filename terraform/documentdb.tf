resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 2
  identifier         = "docdb-cluster-nodejs-app-${count.index}"
  cluster_identifier = aws_docdb_cluster.nodejs-app.id
  instance_class     = "db.r5.large"
}

resource "aws_docdb_cluster" "nodejs-app" {
  cluster_identifier = "docdb-cluster-nodejs-app"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  engine= "docdb"
  db_subnet_group_name = module.vpc.private_subnets
  master_username    = jsondecode(data.aws_secretsmanager_secret_version.documentdb-secrets.secret_string)["DB_USERNAME"]
  master_password    = jsondecode(data.aws_secretsmanager_secret_version.documentdb-secrets.secret_string)["DB_PASSWORD"]
}