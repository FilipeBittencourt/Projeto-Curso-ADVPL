using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019093002 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
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
           

            migrationBuilder.AddColumn<string>(
                name: "EmailCC",
                table: "Mail",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EmailCCO",
                table: "Mail",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EmailCC",
                table: "Mail");

            migrationBuilder.DropColumn(
                name: "EmailCCO",
                table: "Mail");          

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

            migrationBuilder.AddColumn<int>(
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
        }
    }
}
