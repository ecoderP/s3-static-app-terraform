terraform init -migrate-state -backend-config=dev.tfbackend
terraform init -reconfigure -backend-config=dev.tfbackend

- name: Debug GitHub Context
  run: |
  echo "Repository: ${{ github.repository }}"
  echo "Ref: ${{ github.ref }}"
  echo "Environment: prod"
