select *
from Housing_Data..Nashville_data$
--
-- Formatting the datetime column "salesdate" into only that shows the data
Select salesdateconverted
FROM Housing_Data..Nashville_data$

ALTER TABLE Nashville_data$
ADD SalesDateconverted date

Update Nashville_data$
SET SalesDateconverted = convert(date,SalesDateconverted)

-- Removing Null from property address
SELECT a.parcelid, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Housing_Data..Nashville_data$ a
join Nashville_data$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


Update b
SET PropertyAddress = isnull(b.propertyaddress, a.propertyaddress)
from Housing_Data..Nashville_data$ a
join Nashville_data$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE b.PropertyAddress is NULL

-- Separate city in the property address column
Select substring(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, len(propertyaddress)) as City
from Housing_Data..Nashville_data$ 

-- Add new column for address without comma
Alter table housing_data..Nashville_data$
Add Address nvarchar(255)
Update Housing_Data..Nashville_data$
SET Address = substring(PropertyAddress,1, CHARINDEX(',' , PropertyAddress)-1)

-- add new column to separate out the city
Alter table housing_data..Nashville_data$
Add City nvarchar(255)
Update Housing_Data..Nashville_data$
SET city = substring(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, len(propertyaddress))

--check updated rows
SELECT address, city
from Housing_Data..Nashville_data$

--change y and n to yes and no in soldvacant column

select distinct(soldasvacant)
from Housing_Data..Nashville_data$

select soldasvacant,
	case when soldasvacant = 'N' then 'No'
	When soldasvacant = 'Y' then 'Yes'
	ELSE SoldAsVacant
	End as Uniform_SoldasVacant
FROM Housing_Data..Nashville_data$

Update Housing_Data..Nashville_data$
SET soldasvacant = case when soldasvacant = 'N' then 'No'
	When soldasvacant = 'Y' then 'Yes'
	ELSE SoldAsVacant END

-- Using delimiters to arrange address data in a better manner
Select OwnerAddress
from Housing_Data..Nashville_data$

Select owneraddress, parsename(replace(owneraddress, ',', '.'),3),
parsename(replace(owneraddress, ',', '.'),2),
parsename(replace(owneraddress, ',', '.'),1)
FROM Housing_Data..Nashville_data$

Alter table Housing_Data..Nashville_data$
ADD ownerstate nvarchar(255),
 ownercity nvarchar(255),
Aownersplitaddress nvarchar(255)

Update Housing_Data..Nashville_data$
SET ownerstate = parsename(replace(owneraddress, ',', '.'),1),
   ownercity = parsename(replace(owneraddress, ',', '.'),2),
   ownersplitaddress = parsename(replace(owneraddress, ',', '.'),3)

Select OwnerAddress, ownercity, ownersplitaddress, ownerstate
from Housing_Data..Nashville_data$

-- remove duplicate rows
-- Using CTE
WITH RemDup AS(
SELECT *, 
row_number() OVER (partition by
							ParcelID,
							saleprice,
							Saledate,
							legalreference
							ORDER BY uniqueID) row_num
from Housing_Data..Nashville_data$
)
SELECT *
from RemDup
where row_num>1





