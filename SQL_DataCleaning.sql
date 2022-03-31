-- Cleaning Data in SQL project

select *
from [AtA portfolio project_3]..[nashville housing];

----------------------------------------------------------------------------------------------------------------

-- Change sale date format
select SaleDate, CONVERT(date,SaleDate)
from [AtA portfolio project_3]..[nashville housing]

--This method did not take effect for some reason so I will alter table instead
update [nashville housing]
Set SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE [nashville housing]
add SaleDateConverted Date;

update [nashville housing] 
set SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted
from [AtA portfolio project_3]..[nashville housing]

----------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- Null values in property address
select *
from [nashville housing]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, b.ParcelID, b.PropertyAddress , a.PropertyAddress
from [nashville housing] a
join [nashville housing] b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL

-- add propery address from duplicate table b to fill nulls in original
UPDATE a
set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from [nashville housing] a
join [nashville housing] b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] --exclude duplicate lines
WHERE A.PropertyAddress IS NULL

-- check
select *
from [nashville housing]
where PropertyAddress is null
-- success

----------------------------------------------------------------------------------------------------------------

-- Slicing Address into segments (Address and City) 

select *
from [nashville housing]

select SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) as City
from [nashville housing]

alter table [nashville housing]
add SplitAddress nvarchar(255);

update [nashville housing]
set SplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table [nashville housing]
add SplitCity nvarchar(255);

update [nashville housing]
set SplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress))

-- check
select SplitAddress, SplitCity
from [nashville housing]
-- yes


-- Slicing owner address using replace to enable parsename function
select OwnerAddress
from [AtA portfolio project_3]..[nashville housing]

select PARSENAME(Replace(owneraddress,',', '.'),3)
, PARSENAME(Replace(owneraddress,',', '.'),2)
, PARSENAME(Replace(owneraddress,',', '.'),1)
from [AtA portfolio project_3]..[nashville housing]

alter TABLE [AtA portfolio project_3]..[nashville housing]
add OwnerSplitAddress nvarchar(255);

Update [AtA portfolio project_3]..[nashville housing]
set OwnerSplitAddress = PARSENAME(Replace(owneraddress,',', '.'),3)

alter table [AtA portfolio project_3]..[nashville housing]
add OwnerSplitCity nvarchar(255);

Update [AtA portfolio project_3]..[nashville housing]
set OwnerSplitCity = PARSENAME(Replace(owneraddress,',', '.'),2)

alter table [AtA portfolio project_3]..[nashville housing]
add OwnerSplitState nvarchar(255);

Update [AtA portfolio project_3]..[nashville housing]
set OwnerSplitState = PARSENAME(Replace(owneraddress,',', '.'),1)

--check
select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from [AtA portfolio project_3]..[nashville housing]
--yes

----------------------------------------------------------------------------------------------------------------

-- Change Y/N to Yes/No
select Distinct(SoldAsVacant), Count(soldasvacant)
from [AtA portfolio project_3]..[nashville housing]
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from [AtA portfolio project_3]..[nashville housing]

update [AtA portfolio project_3]..[nashville housing]
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

-- check
select Distinct(SoldAsVacant), Count(soldasvacant)
from [AtA portfolio project_3]..[nashville housing]
group by SoldAsVacant
order by 2
-- yes

----------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- if rownum is greater than 1, then this indicates duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() over (
	partition by parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by
					uniqueid
					) rownum
from [AtA portfolio project_3]..[nashville housing])
-- this section needs review


----------------------------------------------------------------------------------------------------------------

-- Delete unused columns

select * 
from [AtA portfolio project_3]..[nashville housing]


ALTER TABLE [AtA portfolio project_3]..[nashville housing]
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER TABLE [AtA portfolio project_3]..[nashville housing]
DROP COLUMN saledate

select * 
from [AtA portfolio project_3]..[nashville housing]
