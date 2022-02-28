output control_plane_sg_id {
  value = aws_security_group.control_plane_sg.id
}

output worker_nodes_sg_id {
  value = aws_security_group.data_plane_sg.id
}

output elb_sg_id {
  value = aws_security_group.elb_sg.id
}

output bastion_sg_id {
  value = aws_security_group.bastion_sg.id
}
