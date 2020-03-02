$(info "======= fip_s5p4418.mk enter =========")

FIP_LOADER_BIN := $(PRODUCT_OUT)/fip-loader-usb.bin
FIP_LOADER_IMG := $(PRODUCT_OUT)/fip-loader-usb.img

$(FIP_LOADER_IMG): $(BL2_BIN) $(UBOOT_BIN)
	$(hide) echo "=========== FIP_LOADER_BIN Building !!! =========="
	dd if=$(LOADER_BIN) of=$(FIP_LOADER_BIN) seek=0 bs=1
	dd if=$(SECURE_BIN) of=$(FIP_LOADER_BIN) seek=35840 bs=1
	dd if=$(NONSECURE_BIN) of=$(FIP_LOADER_BIN) seek=64512 bs=1
	python vendor/nexell/tools/nsihtxtmod.py $(PRODUCT_OUT) $(FIP_LOADER_BIN) $(FIP_LOAD_ADDR) $(FIP_JUMP_ADDR)
	python vendor/nexell/tools/nsihbingen.py $(PRODUCT_OUT)/nsih-usbdownload.txt $(FIP_LOADER_IMG)
	dd if=$(FIP_LOADER_BIN) >> $(FIP_LOADER_IMG)


.PHONY : $(FIP_LOADER_IMG)

fip_s5p4418: $(FIP_LOADER_IMG)

ALL_DEFAULT_INSTALLED_MODULES += $(FIP_LOADER_IMG)


$(info "======= fip_s5p4418.mk exit =========")
