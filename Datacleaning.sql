select * from [Portfolio Projects].dbo.NashvilleHousing;
----------------------------------------------------------------------------------------------------------------------------------------------
-- Date format
select SaleDate, CONVERT(Date,SaleDate) from [Portfolio Projects].dbo.NashvilleHousing;
---------------------------------------------------------------------------------------------------------------------------------------------------------
--Property  Address  ( if the propert adress is null populate the value of property adress, with same paercel id.) 
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyAddress,b.propertyAddress)   from [Portfolio Projects].dbo.NashvilleHousing a 
INNER JOIN 
[Portfolio Projects].dbo.NashvilleHousing b on a.[UniqueID ] <> b.[UniqueID ] AND a.ParcelID= b.ParcelID where a.PropertyAddress is null

update a 
set PropertyAddress = ISNULL(a.propertyAddress,b.propertyAddress)   from [Portfolio Projects].dbo.NashvilleHousing a 
INNER JOIN 
[Portfolio Projects].dbo.NashvilleHousing b on a.[UniqueID ] <> b.[UniqueID ] AND a.ParcelID= b.ParcelID where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------
-- Breaking address into address,city,state
select SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) as address1  from [Portfolio Projects].dbo.NashvilleHousing;

 Alter table [Portfolio Projects].dbo.NashvilleHousing 
 add PropertySplitAddress NVARCHAR(255);

Update [Portfolio Projects].dbo.NashvilleHousing
SET PropertySplitAddress =SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1);

 Alter table [Portfolio Projects].dbo.NashvilleHousing 
 add PropertySplitCity NVARCHAR(255);

 Update [Portfolio Projects].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))
-----------------------------------------------------------------------------------------------------------------------
-- Breaking Owner address into adress,city,state
select SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) as addressO ,
SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,CHARINDEX(',',OwnerAddress)+1) as addresss from [Portfolio Projects].dbo.NashvilleHousing

-- Parsename function works for period hence we need to replace the comma with period and then search, also it displas in the reverse order.. hence 3 is added first
select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Projects].dbo.NashvilleHousing;

 Alter table [Portfolio Projects].dbo.NashvilleHousing 
 add OwnerSplitAddress NVARCHAR(255);

 update [Portfolio Projects].dbo.NashvilleHousing
 set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

  Alter table [Portfolio Projects].dbo.NashvilleHousing 
 add OwnerSplitCity NVARCHAR(255);

 update [Portfolio Projects].dbo.NashvilleHousing
 set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

  Alter table [Portfolio Projects].dbo.NashvilleHousing 
 add OwnerSplitState NVARCHAR(255);

 update [Portfolio Projects].dbo.NashvilleHousing
 set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes  No in sold as vacant field 

select SoldAsVacant, 
CASE 
when SoldAsVacant= 'Y' THEN 'Yes'
when SoldAsVacant= 'N' THEN  'No'
ELSE SoldAsVacant
end as SAV from [Portfolio Projects].dbo.NashvilleHousing

update  [Portfolio Projects].dbo.NashvilleHousing
set SoldAsVacant =CASE 
when SoldAsVacant= 'Y' THEN 'Yes'
when SoldAsVacant= 'N' THEN  'No'
ELSE SoldAsVacant
end

select distinct(SoldAsVacant) from [Portfolio Projects].dbo.NashvilleHousing;

----------------------------------------------------------------------------------------------------------------------------------------
-- remove duplicates

with rownumCTE AS (
select * ,
ROW_NUMBER() OVER( 
PARTITION BY PARCELID,SALEPRICE,SALEDATE,LEGALReference
ORDER BY uniqueid) rownum
from 
[Portfolio Projects].dbo.NashvilleHousing)

SELECT * FROM rownumCTE where rownum >1

delete * from rownumCTE where rownum >1

---------------------------------------------------
 -- remove unused columns  do this with caution its not a good practice to delete.
 
 Alter table [Portfolio Projects].dbo.NashvilleHousing
 drop column PropertyAddress, SaleDate,OwnerAddress,TaxDistrict;


