#!/bin/bash
set -e
echo "SEDding files"
sed -i -r -e 's|<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="2.2.1" />|<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="2.2.0" />|' src/SimplCommerce.WebHost/SimplCommerce.WebHost.csproj
cat src/SimplCommerce.WebHost/SimplCommerce.WebHost.csproj
echo "GREP"
grep EntityFrameworkCore src/SimplCommerce.WebHost/SimplCommerce.WebHost.csproj
sed -i -r -e 's/UseSqlServer/UseNpgsql/' src/SimplCommerce.WebHost/Program.cs
sed -i -r -e 's/UseSqlServer/UseNpgsql/' src/SimplCommerce.WebHost/Extensions/ServiceCollectionExtensions.cs

sed -i -r -e "s/DB_CONNECTION_PLACEHOLDER/${DB_CONNECTION}/" src/SimplCommerce.WebHost/appsettings.json
echo "SED done"

rm -rf src/SimplCommerce.WebHost/Migrations/*
echo "DOTNET BUILD CMD"
dotnet restore && dotnet build

cd src/SimplCommerce.WebHost \
	&& dotnet ef migrations add initialSchema \
	&& dotnet ef database update
	
echo "The database schema has been created. Please execute the src/Database/StaticData_Postgres.sql to insert static data."
echo "Then type 'dotnet run' in src/SimplCommerce.WebHost to start the app."
