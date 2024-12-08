# Public Load Balancer
resource "oci_load_balancer" "produccionPublicLoadBalancer" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }
  compartment_id = oci_identity_compartment.produccionCompartment.id
  subnet_ids = [
    oci_core_subnet.produccionLBSubnet.id
  ]
  display_name               = "produccionPublicLoadBalancer"
  network_security_group_ids = [oci_core_network_security_group.produccionWebSecurityGroup.id]
}

# LoadBalancer Listener
resource "oci_load_balancer_listener" "produccionPublicLoadBalancerListener" {
  load_balancer_id         = oci_load_balancer.produccionPublicLoadBalancer.id
  name                     = "produccionPublicLoadBalancerListener"
  default_backend_set_name = oci_load_balancer_backendset.produccionPublicLoadBalancerBackendset.name
  port                     = 80
  protocol                 = "HTTP"
}

# LoadBalancer Backendset
resource "oci_load_balancer_backendset" "produccionPublicLoadBalancerBackendset" {
  name             = "produccionPublicLBBackendset"
  load_balancer_id = oci_load_balancer.produccionPublicLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# LoadBalanacer Backend for WebServer1 Instance
resource "oci_load_balancer_backend" "produccionPublicLoadBalancerBackend1" {
  load_balancer_id = oci_load_balancer.produccionPublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.produccionPublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.produccionWebserver1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# LoadBalanacer Backend for WebServer2 Instance
resource "oci_load_balancer_backend" "produccionPublicLoadBalancerBackend2" {
  load_balancer_id = oci_load_balancer.produccionPublicLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.produccionPublicLoadBalancerBackendset.name
  ip_address       = oci_core_instance.produccionWebserver2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

