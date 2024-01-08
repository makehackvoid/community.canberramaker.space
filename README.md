# community.canberramaker.space

Forked from [discourse/discourse](https://github.com/discourse/discourse)

MHV note: we have a forked version of discourse/discourse as NixOS has opinions around `/bin/bash`. Fork differs from upstream in `bin/docker/*` scripts by replacing shebang with `#!/usr/bin/env bash`.

## Running the development environment

```
# Install dependencies for backend and frontend
./d/boot_dev --init
    # wait while:
    #   - dependencies are installed,
    #   - the database is migrated, and
    #   - an admin user is created (you'll need to interact with this)

# Start the backend:
./d/rails s

# Start the frontend:
./d/ember-cli
```

### Troubleshooting

ember-cli bootstrap may do strange things with node_modules permissions so may require to chown:

```
sudo chown -R $USER node_modules
```
