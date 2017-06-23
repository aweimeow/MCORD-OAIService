# M-CORD Service - Open Air Interface

## Installation Guide

First, you need to ssh into production machine - `prod`.
And clone this repository from GitHub.

```bash
ssh prod
git clone https://github.com/aweimeow/MCORD-OAIService ~/xos_services/oai
```

Then, you must to change mcord MakeFile Configuration.

```bash
    onboarding:

        ...

        sudo cp id_rsa key_import/oai_rsa
        sudo cp id_rsa.pub key_import/oai_rsa.pub
        
        ...

        $(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/oai/xos/oai-onboard.yaml

        ...

        bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/oai

        ...
```