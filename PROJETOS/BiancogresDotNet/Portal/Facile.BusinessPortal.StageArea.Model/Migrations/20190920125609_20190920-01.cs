using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _2019092001 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Codigo",
                table: "EmpresaInterface",
                nullable: false,
                oldClrType: typeof(string),
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "CNPJ",
                table: "EmpresaInterface",
                nullable: false,
                oldClrType: typeof(string),
                oldNullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "Client_Key",
                table: "EmpresaInterface",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<string>(
                name: "Secret_Key",
                table: "EmpresaInterface",
                nullable: false,
                defaultValue: "");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Client_Key",
                table: "EmpresaInterface");

            migrationBuilder.DropColumn(
                name: "Secret_Key",
                table: "EmpresaInterface");

            migrationBuilder.AlterColumn<string>(
                name: "Codigo",
                table: "EmpresaInterface",
                nullable: true,
                oldClrType: typeof(string));

            migrationBuilder.AlterColumn<string>(
                name: "CNPJ",
                table: "EmpresaInterface",
                nullable: true,
                oldClrType: typeof(string));
        }
    }
}
