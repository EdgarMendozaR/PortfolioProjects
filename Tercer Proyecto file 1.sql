/* 
Cleaning DAata in SQL Querries
*/

Select *
from PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDate, CONVERT(date, saledate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,saledate) -- no actualiza la columna en la tabla original

alter table nashvilleHousing
add saleDateConverted Date;

update NashvilleHousing
set saleDateConverted = CONVERT(date,saledate)

Select saleDateConverted, CONVERT(date, saledate) -- aca vemos que agregando una columna nueva y añadiendole los valores convertidos si pudimos crear la columna con el formato deseado
from PortfolioProject..NashvilleHousing 
 

-------------------------------------------------------------------------------------------------------------------

-- Populate Property Adres Data

select PropertyAddress
from NashvilleHousing
-- where PropertyAddress is null

Select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) -- estamos encontrando con que llena los Property adress que estan null
from NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
	where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



-------------------------------------------------------------------------------------------------------------------

--Breaking out Adress into Individual Columns (Adress, city, State)

select PropertyAddress
from NashvilleHousing

select
SUBSTRING( PropertyAddress, 1, CHARINDEX( ',',PropertyAddress)-1) as Address,-- Busca desde el valor "1" hasta que encuentra el valor "," en la columna indicada
SUBSTRING(PropertyAddress,CHARINDEX( ',',PropertyAddress)+1, len (propertyaddress))
from NashvilleHousing

--Se crean dos nuevas columnas y se añaden los valores separados que hemos hallado de las diecciones
alter table nashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX( ',',PropertyAddress)-1)

alter table nashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX( ',',PropertyAddress)+1, len (propertyaddress))

select * -- Se aprecian las nuevas columnas agregadas al final de la tabla
from NashvilleHousing


/* Probando otra forma parralela a los substrings*/

select OwnerAddress
from NashvilleHousing

select OwnerAddress, PARSENAME (replace(OwnerAddress,',','.'),3),
PARSENAME (replace(OwnerAddress,',','.'),2),
PARSENAME (replace(OwnerAddress,',','.'),1)
from NashvilleHousing

alter table nashvilleHousing
add OwnerSplitAddress nvarchar(255);

 /* Se crean 3 nuevas columnas en nuestra tabla con la modificacion que deseamos para que la data sea mas manejable*/

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (replace(OwnerAddress,',','.'),3)

alter table nashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME (replace(OwnerAddress,',','.'),2)

alter table nashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME (replace(OwnerAddress,',','.'),1)

select *
from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct( SoldAsVacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with RowNumCTE as (
select *, ROW_NUMBER() over (
		  partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		  order by uniqueID)
		  row_num
		
from NashvilleHousing	
--order by ParcelID
)

--Select * // luego de ver que la tabla cumple con los requisitos que queriamos podemos borrarla
delete
from RowNumCTE
where row_num > 1 
--order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
From NashvilleHousing

alter table nashvillehousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table nashvillehousing
drop column SaleDate


















--Importing Data using OPENROWSET and BULK INSERT

-- More advanced and looks cooler, but have to configure server appropriately to do correctly
-- Wanted to provide this in case you wanted to try it

--sp_configure ' Show advanced options', 1;
--RECONFIGURE
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--GO

--USE PortfolioProject

--GO

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess',1

--GO

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters',1

--GO


----Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing from 'C:\Temp\SQL Server Management Studio\Nashville Housing Data For Data Cleaning Project.csv'
-- With(
--		FIELDTERMINATOR = ',',
--		ROWTERMINATOR = '\n'
--);
--GO

---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO snashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--		'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv',[Sheet1$]);
--GO


