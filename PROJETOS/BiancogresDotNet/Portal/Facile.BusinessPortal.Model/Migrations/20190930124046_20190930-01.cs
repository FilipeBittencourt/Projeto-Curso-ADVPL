using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019093001 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TokenConfirm",
                table: "Usuario",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "TokenValid",
                table: "Usuario",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TokenConfirm",
                table: "Usuario");

            migrationBuilder.DropColumn(
                name: "TokenValid",
                table: "Usuario");
        }
    }
}
