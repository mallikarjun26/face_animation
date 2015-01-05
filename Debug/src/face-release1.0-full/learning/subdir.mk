################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CC_SRCS += \
../src/face-release1.0-full/learning/lincomb.cc \
../src/face-release1.0-full/learning/qp_one_sparse.cc \
../src/face-release1.0-full/learning/score.cc 

OBJS += \
./src/face-release1.0-full/learning/lincomb.o \
./src/face-release1.0-full/learning/qp_one_sparse.o \
./src/face-release1.0-full/learning/score.o 

CC_DEPS += \
./src/face-release1.0-full/learning/lincomb.d \
./src/face-release1.0-full/learning/qp_one_sparse.d \
./src/face-release1.0-full/learning/score.d 


# Each subdirectory must supply rules for building sources it contributes
src/face-release1.0-full/learning/%.o: ../src/face-release1.0-full/learning/%.cc
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


