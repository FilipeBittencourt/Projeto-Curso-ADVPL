using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019092603 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "EmailCC",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EmailCCO",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MailDisplayName",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MailHost",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MailPassword",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MailPort",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MailSender",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MailUser",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "SSL",
                table: "PerfilEmpresa",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "UseCustomMailServer",
                table: "PerfilEmpresa",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EmailCC",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "EmailCCO",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "MailDisplayName",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "MailHost",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "MailPassword",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "MailPort",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "MailSender",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "MailUser",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "SSL",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "UseCustomMailServer",
                table: "PerfilEmpresa");
        }
    }
}
