################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CC_SRCS += \
../src/face-release1.0-full/detection/fconv.cc \
../src/face-release1.0-full/detection/fconvMT.cc \
../src/face-release1.0-full/detection/fconvblas.cc \
../src/face-release1.0-full/detection/features.cc \
../src/face-release1.0-full/detection/reduce.cc \
../src/face-release1.0-full/detection/resize.cc \
../src/face-release1.0-full/detection/shiftdt.cc 

OBJS += \
./src/face-release1.0-full/detection/fconv.o \
./src/face-release1.0-full/detection/fconvMT.o \
./src/face-release1.0-full/detection/fconvblas.o \
./src/face-release1.0-full/detection/features.o \
./src/face-release1.0-full/detection/reduce.o \
./src/face-release1.0-full/detection/resize.o \
./src/face-release1.0-full/detection/shiftdt.o 

CC_DEPS += \
./src/face-release1.0-full/detection/fconv.d \
./src/face-release1.0-full/detection/fconvMT.d \
./src/face-release1.0-full/detection/fconvblas.d \
./src/face-release1.0-full/detection/features.d \
./src/face-release1.0-full/detection/reduce.d \
./src/face-release1.0-full/detection/resize.d \
./src/face-release1.0-full/detection/shiftdt.d 


# Each subdirectory must supply rules for building sources it contributes
src/face-release1.0-full/detection/%.o: ../src/face-release1.0-full/detection/%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


