# Contributing Guide

Thank you for your interest in contributing to the self-service platform!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Submit a pull request

## Development Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/self-service.git
cd self-service

# Run the setup script
./scripts/setup.sh

# Start developing!
```

## Project Structure

- `backstage/` - Backstage portal configuration
- `terraform/` - Infrastructure as Code modules
- `templates/` - Backstage software templates
- `.github/workflows/` - CI/CD workflows
- `docs/` - Documentation
- `scripts/` - Helper scripts

## Making Changes

### Adding a New Template

1. Create a new directory in `templates/`
2. Create `template.yaml` with the template definition
3. Create a `skeleton/` directory with the template files
4. Update `backstage/app-config.yaml` to include the new template
5. Test the template in Backstage

### Modifying Terraform Modules

1. Make changes to `terraform/modules/`
2. Update the module version or create a new version
3. Test with `terraform plan` in `terraform/examples/`
4. Update documentation in the module's README
5. Update any dependent templates

### Updating Documentation

1. Edit files in `docs/`
2. Ensure examples are working
3. Update screenshots if UI changes
4. Run spell check

## Code Style

### Terraform

- Use 2 spaces for indentation
- Run `terraform fmt` before committing
- Add comments for complex logic
- Use meaningful variable names
- Include descriptions for all variables and outputs

### YAML

- Use 2 spaces for indentation
- Quote strings when necessary
- Keep lines under 80 characters when possible

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Add comments for non-obvious commands
- Test on Ubuntu

## Testing

### Test Terraform Modules

```bash
cd terraform/examples/basic-project
terraform init
terraform validate
terraform plan
```

### Test Backstage Templates

1. Start Backstage locally
2. Navigate to "Create"
3. Fill out the template form
4. Verify generated files
5. Test GitHub Actions workflow

### Test Documentation

1. Follow the getting started guide
2. Verify all commands work
3. Check all links

## Pull Request Process

1. **Update Documentation**: Ensure docs reflect your changes
2. **Test Thoroughly**: Test on a clean environment
3. **Write Clear Commits**: Use descriptive commit messages
4. **Small PRs**: Keep changes focused and reviewable
5. **Link Issues**: Reference any related issues

### Commit Message Format

```
type(scope): brief description

Detailed explanation if needed

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

Examples:
- `feat(templates): add kubernetes cluster template`
- `fix(terraform): correct subnet cidr validation`
- `docs(readme): update installation instructions`

## Review Process

1. Automated checks must pass
2. At least one approval required
3. All comments must be resolved
4. Squash and merge to main

## Release Process

1. Update version numbers
2. Update CHANGELOG.md
3. Create a git tag
4. Create a GitHub release
5. Update documentation

## Getting Help

- Check existing issues and discussions
- Read the documentation in `docs/`
- Ask questions in GitHub Discussions
- Join our community chat (if available)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Assume good intentions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Recognition

Contributors will be recognized in:
- README.md
- Release notes
- Project documentation

Thank you for contributing!
