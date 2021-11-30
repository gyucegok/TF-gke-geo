# Secure Google Kubernetes Engine IaC Terraform Project

This Terraform project includes static code testing and code security analysis for safe IaC development. It creates a pair of GKE clusters. Variables need to be exposed as environment variables for privacy and safety

## Installation/Hydration

Export your variables as environment variables and run the subenv.sh script

```bash
export TF_FOLDER_ID=12345
export TF_BILLING_ACCOUNT="AAA-BBB-CCC"
export TF_PROJECT_NAME=myproject
export TF_NETWORK_NAME=myvpc
```

## Usage

Do your static code analysis with the included code-test.sh script. The analysis for each tool will be stored in the static-analysis folder

```bash
/bin/bash code-test.sh
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)
