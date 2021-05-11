using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019090201 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "UsuarioSacado",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "UsuarioSacado",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "UsuarioSacado",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "UsuarioFornecedor",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "UsuarioFornecedor",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "UsuarioFornecedor",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Usuario",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Usuario",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Usuario",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Unidade",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Unidade",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Unidade",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "TituloPagar",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "TituloPagar",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "TituloPagar",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "TaxaAntecipacao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "TaxaAntecipacao",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "TaxaAntecipacao",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Sacado",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Registro",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Registro",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Registro",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Permissao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Permissao",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Permissao",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Modulo",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Modulo",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Modulo",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "MenuAcao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "MenuAcao",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "MenuAcao",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Menu",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Menu",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Menu",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Mail",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Mail",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Mail",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Lote",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Lote",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Lote",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "LogApiHistorico",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "LogApiHistorico",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "LogApiHistorico",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "LogApi",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "LogApi",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "LogApi",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "LayoutEmail",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "LayoutEmail",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "LayoutEmail",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "GrupoUsuario",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "GrupoUsuario",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "GrupoUsuario",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "GrupoSacado",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "GrupoSacado",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "GrupoSacado",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Fornecedor",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Fornecedor",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Fornecedor",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Empresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Empresa",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Empresa",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "DocumentoPagar",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "DocumentoPagar",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "DocumentoPagar",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "ContaBancaria",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "ContaBancaria",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "ContaBancaria",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "ConfiguracaoArquivo",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "ConfiguracaoArquivo",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "ConfiguracaoArquivo",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Cedente",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Cedente",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Cedente",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Boleto",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Boleto",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Boleto",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "BancoAuth",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "BancoAuth",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "BancoAuth",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Banco",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Banco",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Banco",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Arquivo",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Arquivo",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Arquivo",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "AntecipacaoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "AntecipacaoItem",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "AntecipacaoItem",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "AntecipacaoHistorico",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "AntecipacaoHistorico",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "AntecipacaoHistorico",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Antecipacao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Antecipacao",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Antecipacao",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "AccessToken",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "AccessToken",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "AccessToken",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataHoraIntegracao",
                table: "Acao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MensagemRetorno",
                table: "Acao",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StatusIntegracao",
                table: "Acao",
                nullable: false,
                defaultValue: 0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "UsuarioSacado");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "UsuarioSacado");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "UsuarioSacado");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "UsuarioFornecedor");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "UsuarioFornecedor");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "UsuarioFornecedor");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Usuario");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Usuario");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Usuario");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Unidade");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Unidade");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Unidade");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "TaxaAntecipacao");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "TaxaAntecipacao");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "TaxaAntecipacao");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Registro");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Registro");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Registro");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Permissao");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Permissao");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Permissao");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Modulo");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Modulo");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Modulo");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "MenuAcao");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "MenuAcao");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "MenuAcao");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Menu");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Menu");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Menu");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Mail");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Mail");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Mail");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Lote");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Lote");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Lote");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "LogApiHistorico");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "LogApiHistorico");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "LogApiHistorico");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "LogApi");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "LogApi");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "LogApi");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "LayoutEmail");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "LayoutEmail");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "LayoutEmail");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "GrupoUsuario");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "GrupoUsuario");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "GrupoUsuario");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "GrupoSacado");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "GrupoSacado");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "GrupoSacado");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Empresa");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Empresa");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Empresa");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "DocumentoPagar");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "DocumentoPagar");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "DocumentoPagar");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "ContaBancaria");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "ContaBancaria");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "ContaBancaria");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "ConfiguracaoArquivo");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "ConfiguracaoArquivo");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "ConfiguracaoArquivo");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Cedente");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Cedente");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Cedente");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Boleto");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Boleto");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Boleto");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "BancoAuth");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "BancoAuth");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "BancoAuth");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Banco");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Banco");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Banco");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Arquivo");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Arquivo");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Arquivo");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "AntecipacaoHistorico");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "AntecipacaoHistorico");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "AntecipacaoHistorico");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Antecipacao");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Antecipacao");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Antecipacao");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "AccessToken");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "AccessToken");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "AccessToken");

            migrationBuilder.DropColumn(
                name: "DataHoraIntegracao",
                table: "Acao");

            migrationBuilder.DropColumn(
                name: "MensagemRetorno",
                table: "Acao");

            migrationBuilder.DropColumn(
                name: "StatusIntegracao",
                table: "Acao");
        }
    }
}
