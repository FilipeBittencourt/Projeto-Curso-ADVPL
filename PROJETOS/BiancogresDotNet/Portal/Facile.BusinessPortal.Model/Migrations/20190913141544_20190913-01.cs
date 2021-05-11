using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019091301 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Cor_Header1",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "Cor_Header2",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "Cor_Menu",
                table: "PerfilEmpresa");

            migrationBuilder.AddColumn<long>(
                name: "ThemeID",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Theme",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    CssPath = table.Column<string>(nullable: true),
                    ThemeOptions = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Theme", x => x.ID);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PerfilEmpresa_ThemeID",
                table: "PerfilEmpresa",
                column: "ThemeID");

            migrationBuilder.AddForeignKey(
                name: "FK_PerfilEmpresa_Theme_ThemeID",
                table: "PerfilEmpresa",
                column: "ThemeID",
                principalTable: "Theme",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PerfilEmpresa_Theme_ThemeID",
                table: "PerfilEmpresa");

            migrationBuilder.DropTable(
                name: "Theme");

            migrationBuilder.DropIndex(
                name: "IX_PerfilEmpresa_ThemeID",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "ThemeID",
                table: "PerfilEmpresa");

            migrationBuilder.AddColumn<string>(
                name: "Cor_Header1",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Cor_Header2",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Cor_Menu",
                table: "PerfilEmpresa",
                nullable: true);
        }
    }
}
