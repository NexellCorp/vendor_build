$(info "======= make_uboot_env.mk enter =========")


UBOOT_ENV := uboot_env
$(UBOOT_ENV): $(LOADER_BIN)
	$(hide) echo "=========== make_uboot_env Start !!! =========="
	$(shell vendor/nexell/tools/make_uboot_env.sh)

.PHONY : $(UBOOT_ENV)

ALL_DEFAULT_INSTALLED_MODULES += $(UBOOT_ENV)

$(info "======= make_uboot_env.mk exit =========")
