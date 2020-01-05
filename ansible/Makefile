decrypt:
	for file in $$(find . -name 'ansible_vault.yml' ) ; do \
		environment=$$(basename $$(dirname $${file})) ; \
		unencrypted_name=$$(dirname $${file})/ansible_vault.unencrypted.yml ; \
		mv $${file} $${unencrypted_name} && \
		ansible-vault decrypt --vault-password-file ~/secrets/$${environment}.password $${unencrypted_name} ; \
	done

encrypt:
	for file in $$(find . -name 'ansible_vault.unencrypted.yml' ) ; do \
		environment=$$(basename $$(dirname $${file})) ; \
		unencrypted_name=$$(dirname $${file})/ansible_vault.unencrypted.yml ; \
		encrypted_name=$$(dirname $${file})/ansible_vault.yml ; \
		ansible-vault encrypt --vault-password-file ~/secrets/$${environment}.password $${unencrypted_name} && \
		mv $${unencrypted_name} $${encrypted_name}  ; \
	done
