# Public Load Balancer
resource "oci_load_balancer" "produccionLoadBalancer" {
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
    oci_core_subnet.produccionWebSubnet.id
  ]
  display_name = "produccionLoadBalancer"
}

# LoadBalancer Listener
resource "oci_load_balancer_listener" "produccionLoadBalancerListener" {
  load_balancer_id         = oci_load_balancer.produccionLoadBalancer.id
  name                     = "produccionLoadBalancerListener"
  default_backend_set_name = oci_load_balancer_backendset.produccionLoadBalancerBackendset.name
  port                     = 80
  protocol                 = "HTTP"
}

# LoadBalancer Backendset
resource "oci_load_balancer_backendset" "produccionLoadBalancerBackendset" {
  name             = "produccionLBBackendset"
  load_balancer_id = oci_load_balancer.produccionLoadBalancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

# LoadBalanacer Backend for WebServer1 Instance
resource "oci_load_balancer_backend" "produccionLoadBalancerBackend" {
  load_balancer_id = oci_load_balancer.produccionLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.produccionLoadBalancerBackendset.name
  ip_address       = oci_core_instance.produccionWebserver1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# LoadBalanacer Backend for WebServer2 Instance
resource "oci_load_balancer_backend" "produccionLoadBalancerBackend2" {
  load_balancer_id = oci_load_balancer.produccionLoadBalancer.id
  backendset_name  = oci_load_balancer_backendset.produccionLoadBalancerBackendset.name
  ip_address       = oci_core_instance.produccionWebserver2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}


