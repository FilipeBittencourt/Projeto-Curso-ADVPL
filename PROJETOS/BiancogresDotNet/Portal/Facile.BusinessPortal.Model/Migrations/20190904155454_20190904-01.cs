using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019090401 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
           
            migrationBuilder.AddColumn<string>(
                name: "EmailWorkflow",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EmailWorkflow",
                table: "Fornecedor",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EmailWorkflow",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "EmailWorkflow",
                table: "Fornecedor");
        }
    }
}
