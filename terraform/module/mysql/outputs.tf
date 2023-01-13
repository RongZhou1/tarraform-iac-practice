output "db_type" {
  value = local.is_selfbuilt ? module.self_built.0.db_type : "unknown"
}
output "mysql_db_host" {
  value = local.is_selfbuilt ? module.self_built.0.mysql_db_host : "unknown"
}
output "mysql_db_port" {
  value = local.is_selfbuilt ? module.self_built.0.mysql_db_port : "unknown"
}
output "mysql_db_user" {
  value = local.is_selfbuilt ? module.self_built.0.mysql_db_user : "unknown"
}
output "mysql_db_password" {
  value = local.is_selfbuilt ? module.self_built.0.mysql_db_password : "unknown"
}
