output "ip_address" {
  description = "Static IP address for the external LB"
  value       = google_compute_address.ip_address.address
}