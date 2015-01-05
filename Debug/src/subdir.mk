################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/BuildFeatureVectors.cpp \
../src/BuildListOfSelectedFaces.cpp \
../src/ConstructGraph.cpp \
../src/ExtractFaces.cpp \
../src/ExtractFrames.cpp \
../src/FilterFaces.cpp \
../src/TraversalDijkstra.cpp \
../src/main.cpp 

OBJS += \
./src/BuildFeatureVectors.o \
./src/BuildListOfSelectedFaces.o \
./src/ConstructGraph.o \
./src/ExtractFaces.o \
./src/ExtractFrames.o \
./src/FilterFaces.o \
./src/TraversalDijkstra.o \
./src/main.o 

CPP_DEPS += \
./src/BuildFeatureVectors.d \
./src/BuildListOfSelectedFaces.d \
./src/ConstructGraph.d \
./src/ExtractFaces.d \
./src/ExtractFrames.d \
./src/FilterFaces.d \
./src/TraversalDijkstra.d \
./src/main.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I/usr/local/include/opencv -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


