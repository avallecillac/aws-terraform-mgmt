terraform {
    backend "s3" {
        bucket         = "{{ your_infrastructure_state_bucket }}"
        encrypt        = true
        key            = "{{ your_infrastructure_state_key }}"
        region         = " {{ your_region }}"
    }
}
