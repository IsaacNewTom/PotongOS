nasm -f bin -o PotongBoot.bin boot.asm
# nasm -f bin -o loader.bin loader.asm
dd if=PotongBoot.bin of=PotongBoot.img bs=512 count=1 conv=notrunc
# dd if=loader.bin of=boot.img bs=512 count=5 seek=1 conv=notrunc
