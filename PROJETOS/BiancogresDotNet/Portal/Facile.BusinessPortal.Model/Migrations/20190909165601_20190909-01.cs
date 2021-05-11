using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019090901 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "UsuarioSacado",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "UsuarioFornecedor",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Usuario",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Unidade",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "TituloPagar",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "TaxaAntecipacao",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Registro",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Permissao",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Parametro",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Modulo",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "MenuAcao",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Menu",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Mail",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Lote",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "LayoutEmail",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "GrupoUsuario",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "GrupoSacado",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Fornecedor",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "DocumentoPagar",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "ContaBancaria",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "ConfiguracaoArquivo",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Cedente",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Boleto",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "BancoAuth",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Arquivo",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "AntecipacaoItem",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "AntecipacaoHistorico",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Antecipacao",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "StageID",
                table: "Acao",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StageID",
                table: "UsuarioSacado");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "UsuarioFornecedor");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Usuario");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Unidade");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "TaxaAntecipacao");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Registro");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Permissao");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Parametro");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Modulo");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "MenuAcao");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Menu");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Mail");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Lote");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "LayoutEmail");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "GrupoUsuario");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "GrupoSacado");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "DocumentoPagar");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "ContaBancaria");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "ConfiguracaoArquivo");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Cedente");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Boleto");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "BancoAuth");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Arquivo");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "AntecipacaoHistorico");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Antecipacao");

            migrationBuilder.DropColumn(
                name: "StageID",
                table: "Acao");
        }
    }
}
