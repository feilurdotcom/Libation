# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Copy source code to the container
COPY Source /Source

# Argument for target platform
ARG TARGETPLATFORM

# Echo the target platform to verify it's passed correctly
# Use a simpler syntax to avoid potential issues
RUN echo "Target Platform: $TARGETPLATFORM"

# Publish the .NET project for the specified runtime
# Note: The TARGETPLATFORM should be converted to a valid RID (e.g., linux-x64)
# For demonstration purposes, assuming a conversion is needed
RUN RID=${TARGETPLATFORM//\//-} && dotnet publish -r $RID -c Release -o /Source/bin/Publish/Linux-chardonnay /Source/LibationCli/LibationCli.csproj -p:PublishProfile=/Source/LibationCli/Properties/PublishProfiles/LinuxProfile.pubxml

# Copy the liberation script to the output directory
COPY Docker/liberate.sh /Source/bin/Publish/Linux-chardonnay

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/runtime:8.0

# Environment variables
ENV SLEEP_TIME "30m"

# Sets the character set for folder and filenames when liberating
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Create necessary directories
RUN mkdir /db /config /data

# Copy the published files from the build stage
COPY --from=build-env /Source/bin/Publish/Linux-chardonnay /libation

# Make sure the script is executable
RUN chmod +x /libation/liberate.sh

# Set the entrypoint to the liberation script
ENTRYPOINT ["/libation/liberate.sh"]
