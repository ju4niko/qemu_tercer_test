
#nombre del proyecto
APP=kernel

# nombre del fuente con codigo en C
CCODE=main
#nombre del fuente con codigo en ASM
ACODE=boot

#toolchain
CHAIN=arm-none-eabi

# falgs del compilador
CFLAGS=-std=gnu99 -Wall -mcpu=cortex-a8

#estructura de carpetas del proyecto
OBJ=obj/
BIN=bin/
INC=inc/
SRC=src/
LST=lst/

#linker script
LD=memmap.ld

#placa a emular en la maquina virtual de QEMU
#BOARD=versatilepb
BOARD=realview-pb-a8
#otras placas posibles a emular descomentar la que se quiera usar
#BOARD=mcimx6ul-evk
#BOARD=vexpress-a15
# para ver el listado completo usar el comando:
# qemu-system-arm -M help | grep Cortex-A
# se puede usar cualquiera lo que cambia es el vector de reset en la emualcion
# tener en cuenta esto para modificar el linker script acorde

#opcioin de uso modo grafico
#GRAPHOPT=-nongraphic

#falgs para el QEMU
PORT=12345
VMFLGS= -M $(BOARD) -no-reboot $(GRAPHOPT) -monitor telnet:127.0.0.1:$(PORT),server,nowait

# motor de maquina virtual a utilizar
VME=qemu-system-arm

# binario del kernel a ejecutar en el QEMU
BINF=$(BIN)$(APP).bin

#construccion del proyecto
all: $(BINF) $(OBJ)$(APP).elf

$(BINF): $(OBJ)$(APP).elf
	$(CHAIN)-objcopy -O binary $< $@

# enlazado de los objetos en C y ASM
$(OBJ)$(APP).elf: $(OBJ)$(ACODE).o $(OBJ)$(CCODE).o
	@echo "Linkeando ... "
	mkdir -p obj
	mkdir -p lst

	$(CHAIN)-ld -T $(LD) $(OBJ)*.o -o $(OBJ)$(APP).elf -Map $(LST)$(APP).map
	@echo "Linkeo finalizado!!"
	@echo ""
	@echo "Generando archivos de información: mapa de memoria y símbolos"
	objdump -t $(OBJ)$(APP).elf > $(LST)$(APP).txt
	$(CHAIN)-objdump -D $(OBJ)$(APP).elf > $(LST)$(APP).lst

#ensamblado del codigo en assembler
$(OBJ)$(ACODE).o: $(SRC)$(ACODE).s
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Ensamblando $(ACODE).s ..."
	$(CHAIN)-as -g $(SRC)$(ACODE).s -o $(OBJ)$(ACODE).o -a > $(LST)$(ACODE).lst

#compilado del codigo en C
$(OBJ)$(CCODE).o: $(SRC)$(CCODE).c
	@echo ""
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando $(CCODE).c ..."
	$(CHAIN)-gcc -g -O3 $(CFLAGS) -c $(SRC)$(CCODE).c -o $(OBJ)$(CCODE).o

clean:
	rm -rf $(OBJ)*.o
	rm -rf $(OBJ)*.elf
	rm -rf $(BIN)*.bin
	rm -rf $(LST)*.lst
	rm -rf $(LST)*.txt
	rm -rf $(LST)*.map

run:
	$(VME) $(VMFLGS) -kernel $(BINF)
debug:
	$(VME) $(VMFLGS) -s -S -kernel $(BINF)
connect:
	telnet localhost $(PORT)

