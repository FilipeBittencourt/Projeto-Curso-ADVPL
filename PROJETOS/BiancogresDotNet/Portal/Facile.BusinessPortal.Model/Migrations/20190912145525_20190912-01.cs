using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019091201 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CaminhoDestinoBoletos",
                table: "Unidade");

            migrationBuilder.DropColumn(
                name: "DiretorioBaseArquivo",
                table: "Unidade");

            migrationBuilder.DropColumn(
                name: "SalvaBoletoPdf",
                table: "Unidade");

            migrationBuilder.DropColumn(
                name: "CodigoDV",
                table: "Cedente");

            migrationBuilder.RenameColumn(
                name: "DownloadRetornoPagamento",
                table: "Cedente",
                newName: "EnviaBoletoPDF");

            migrationBuilder.AddColumn<decimal>(
                name: "Multiplicador",
                table: "TaxaAntecipacao",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "TipoTaxa",
                table: "TaxaAntecipacao",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "Customizavel",
                table: "Modulo",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "TipoUsuario",
                table: "Modulo",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "BoletoSenha",
                table: "Cedente",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "BoletoZip",
                table: "Cedente",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "TipoGeracaoSenha",
                table: "Cedente",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Multiplicador",
                table: "TaxaAntecipacao");

            migrationBuilder.DropColumn(
                name: "TipoTaxa",
                table: "TaxaAntecipacao");

            migrationBuilder.DropColumn(
                name: "Customizavel",
                table: "Modulo");

            migrationBuilder.DropColumn(
                name: "TipoUsuario",
                table: "Modulo");

            migrationBuilder.DropColumn(
                name: "BoletoSenha",
                table: "Cedente");

            migrationBuilder.DropColumn(
                name: "BoletoZip",
                table: "Cedente");

            migrationBuilder.DropColumn(
                name: "TipoGeracaoSenha",
                table: "Cedente");

            migrationBuilder.RenameColumn(
                name: "EnviaBoletoPDF",
                table: "Cedente",
                newName: "DownloadRetornoPagamento");

            migrationBuilder.AddColumn<string>(
                name: "CaminhoDestinoBoletos",
                table: "Unidade",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DiretorioBaseArquivo",
                table: "Unidade",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "SalvaBoletoPdf",
                table: "Unidade",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "CodigoDV",
                table: "Cedente",
                nullable: true);
        }
    }
}
