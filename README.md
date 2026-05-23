terraform init -migrate-state -backend-config=dev.tfbackend
terraform init -reconfigure -backend-config=dev.tfbackend

# Just commenting random stuff for debugging

- name: Debug GitHub Context
  run: |
  echo "Repository: ${{ github.repository }}"
  echo "Ref: ${{ github.ref }}"
  echo "Environment: prod"
