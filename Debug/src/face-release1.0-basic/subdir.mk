################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CC_SRCS += \
../src/face-release1.0-basic/fconv.cc \
../src/face-release1.0-basic/fconvMT.cc \
../src/face-release1.0-basic/fconvblas.cc \
../src/face-release1.0-basic/features.cc \
../src/face-release1.0-basic/reduce.cc \
../src/face-release1.0-basic/resize.cc \
../src/face-release1.0-basic/shiftdt.cc 

OBJS += \
./src/face-release1.0-basic/fconv.o \
./src/face-release1.0-basic/fconvMT.o \
./src/face-release1.0-basic/fconvblas.o \
./src/face-release1.0-basic/features.o \
./src/face-release1.0-basic/reduce.o \
./src/face-release1.0-basic/resize.o \
./src/face-release1.0-basic/shiftdt.o 

CC_DEPS += \
./src/face-release1.0-basic/fconv.d \
./src/face-release1.0-basic/fconvMT.d \
./src/face-release1.0-basic/fconvblas.d \
./src/face-release1.0-basic/features.d \
./src/face-release1.0-basic/reduce.d \
./src/face-release1.0-basic/resize.d \
./src/face-release1.0-basic/shiftdt.d 


# Each subdirectory must supply rules for building sources it contributes
src/face-release1.0-basic/%.o: ../src/face-release1.0-basic/%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


