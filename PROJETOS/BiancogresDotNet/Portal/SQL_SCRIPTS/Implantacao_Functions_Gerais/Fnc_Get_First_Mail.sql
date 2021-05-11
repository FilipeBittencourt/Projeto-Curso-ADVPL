alter function Fnc_Get_First_Mail
(
@lst_mail varchar(max)
)
returns varchar(max)
with encryption
as
begin

declare @mail1 varchar(max) = ''

if (CHARINDEX(';',@lst_mail) > 0)
begin

	set @mail1 = rtrim(substring(@lst_mail,1,(CHARINDEX(';',@lst_mail)-1)))

end
else
begin

	set @mail1 = rtrim(@lst_mail)

end

return @mail1

end