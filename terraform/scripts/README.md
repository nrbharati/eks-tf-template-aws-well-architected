# Terraform Scripts

This directory contains helpful scripts for managing your Terraform infrastructure.

## State Management Script

The `manage-state.sh` script helps prevent and resolve common Terraform state lock issues.

### Usage

```bash
# Check for state locks and running processes
./scripts/manage-state.sh check

# Force unlock state with a specific lock ID
./scripts/manage-state.sh unlock <lock_id>

# Clean up local Terraform state files
./scripts/manage-state.sh clean

# Reinitialize Terraform with reconfigure
./scripts/manage-state.sh reinit

# Safe plan execution (checks for conflicts first)
./scripts/manage-state.sh plan

# Safe apply execution (uses saved plan)
./scripts/manage-state.sh apply

# Safe destroy execution (with confirmation)
./scripts/manage-state.sh destroy

# Show help
./scripts/manage-state.sh help
```

### Why Use This Script?

1. **Prevents State Locks**: Checks for running Terraform processes before execution
2. **Easy Lock Resolution**: Simple commands to unlock stuck states
3. **Safe Operations**: Prevents accidental concurrent operations
4. **State Cleanup**: Helps resolve corrupted local state files

### Common Scenarios

#### Scenario 1: State Lock During Apply
```bash
# Check what's happening
./scripts/manage-state.sh check

# If you see a lock, unlock it
./scripts/manage-state.sh unlock <lock_id>

# Then retry your operation
./scripts/manage-state.sh apply
```

#### Scenario 2: Corrupted Local State
```bash
# Clean up local state
./scripts/manage-state.sh clean

# Reinitialize
./scripts/manage-state.sh reinit

# Run plan again
./scripts/manage-state.sh plan
```

#### Scenario 3: Safe Deployment
```bash
# Always use the safe commands for production
./scripts/manage-state.sh plan
./scripts/manage-state.sh apply
```

### Best Practices

1. **Always check before running**: Use `./scripts/manage-state.sh check` before major operations
2. **Use safe commands**: Use `./scripts/manage-state.sh plan/apply` instead of direct terraform commands
3. **Keep plans**: The script saves plans to `plan.out` for safe application
4. **Monitor locks**: Check for locks if operations seem stuck

### Troubleshooting

If you still get state locks:

1. **Check AWS Console**: Look for stuck operations in the EKS console
2. **Verify DynamoDB**: Check the `terraform-state-lock` table in DynamoDB
3. **Contact Team**: If locks persist, there might be a stuck AWS operation
