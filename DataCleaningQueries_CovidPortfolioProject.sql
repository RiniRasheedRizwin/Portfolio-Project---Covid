--Sourcedata - Nashville Housing Data for Data Cleaning.excel

select * from 
[PortfolioProject].[dbo].[NashvilleHousing];

-------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize date format

select 
SaleDate, convert(date,SaleDate)
from 
[PortfolioProject].[dbo].[NashvilleHousing];

update [PortfolioProject].[dbo].[NashvilleHousing]
set SaleDate=convert(date,SaleDate); --This was not working hence going to try with alter table

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add SaleDateConverted date;

update [PortfolioProject].[dbo].[NashvilleHousing]
set SaleDateConverted=convert(date,SaleDate); 

-------------------------------------------------------------------------------------


--populate property address by removing null value

select PropertyAddress,*
from [PortfolioProject].[dbo].[NashvilleHousing]
where PropertyAddress is null;

select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress)
from [PortfolioProject].[dbo].[NashvilleHousing] a
join [PortfolioProject].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b. [UniqueID ]
where a.PropertyAddress is null;

update  a
set a.PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from [PortfolioProject].[dbo].[NashvilleHousing] a
join [PortfolioProject].[dbo].[NashvilleHousing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b. [UniqueID ]
where a.PropertyAddress is null;


---------------------------------------------------------------------------------------------------

--break adress into Address, City, State

 

select PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,LEN(PropertyAddress)) as City
from [PortfolioProject].[dbo].[NashvilleHousing];

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitAddress nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1)
from [PortfolioProject].[dbo].[NashvilleHousing];

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add PropertySplitCity nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,LEN(PropertyAddress))
from [PortfolioProject].[dbo].[NashvilleHousing];


--Parsename function can also be used to split a column into multiple columns in sql, Since parsename identifies period (.)
--only , we have to replace coma(,) with period first

select OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),1) OwnerSplitState,
PARSENAME(replace(OwnerAddress,',','.'),2)OwnerSplitCity,
PARSENAME(replace(OwnerAddress,',','.'),3)OwnerSplitAddress
from [PortfolioProject].[dbo].[NashvilleHousing];

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitState nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)
from [PortfolioProject].[dbo].[NashvilleHousing];

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitCity nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)
from [PortfolioProject].[dbo].[NashvilleHousing];

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Add OwnerSplitAddress nvarchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)
from [PortfolioProject].[dbo].[NashvilleHousing];

select *
from [PortfolioProject].[dbo].[NashvilleHousing];

-------------------------------------------------------------------------------------------------------------------------

--Change Y to Yes and N to No in 'Sold as Vacant' field

select distinct SoldAsVacant, count (SoldAsVacant)
from [PortfolioProject].[dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2;

Select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [PortfolioProject].[dbo].[NashvilleHousing];


Update [PortfolioProject].[dbo].[NashvilleHousing]
set SoldAsVacant = 
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from [PortfolioProject].[dbo].[NashvilleHousing];

------------------------------------------------------------------------------------------------------------------------------------

--Remove duplicates

Select *
from [PortfolioProject].[dbo].[NashvilleHousing];


With RowNumCTE as
(
select ROW_NUMBER() over
(partition by 
	parcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by
	uniqueId
)row_num, *
from [PortfolioProject].[dbo].[NashvilleHousing]
)
select *
rom RowNumCTE
where row_num>1

--delete all those duplicate rows
With RowNumCTE as
(
select ROW_NUMBER() over
(partition by 
	parcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
	order by
	uniqueId
)row_num, *
from [PortfolioProject].[dbo].[NashvilleHousing]
)

delete 
from RowNumCTE
where row_num>1


------------------------------------------------------------------------------------------------------------------------------------


--Delete unused columns

select *
from [PortfolioProject].[dbo].[NashvilleHousing];

Alter table [PortfolioProject].[dbo].[NashvilleHousing]
Drop column owneraddress,propertyaddress, saledate;

------------------------------------------------------------------------------------------------------------------------------------

--Main functions used
--convert()
--alter table
--update table
--replace()
--substring()
--charindex()
--parsename()
--case when 
--row_number()
--over partition by
--CTE
--delete
--drop
