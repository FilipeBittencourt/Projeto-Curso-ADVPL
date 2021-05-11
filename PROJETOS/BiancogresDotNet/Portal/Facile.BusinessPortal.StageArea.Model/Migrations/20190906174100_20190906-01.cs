using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _2019090601 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Boleto",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: false),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    CodigoBanco = table.Column<string>(nullable: true),
                    Cedente_CPFCNPJ = table.Column<string>(nullable: true),
                    Cedente_Codigo = table.Column<string>(nullable: true),
                    Sacado_CPFCNPJ = table.Column<string>(nullable: true),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    DataVencimento = table.Column<DateTime>(nullable: false),
                    DataProcessamento = table.Column<DateTime>(nullable: true),
                    DataCredito = table.Column<DateTime>(nullable: true),
                    ValorTitulo = table.Column<decimal>(nullable: false),
                    ValorOutrosAcrescimos = table.Column<decimal>(nullable: true),
                    NumeroDocumento = table.Column<string>(nullable: true),
                    EspecieDocumento = table.Column<int>(nullable: true),
                    MensagemArquivoRemessa = table.Column<string>(nullable: true),
                    MensagemLivreLinha1 = table.Column<string>(nullable: true),
                    MensagemLivreLinha2 = table.Column<string>(nullable: true),
                    MensagemLivreLinha3 = table.Column<string>(nullable: true),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    NossoNumero = table.Column<string>(nullable: true),
                    CodigoMoeda = table.Column<int>(nullable: true),
                    EspecieMoeda = table.Column<string>(nullable: true),
                    ValorMoeda = table.Column<string>(nullable: true),
                    TipoCarteira = table.Column<int>(nullable: true),
                    Carteira = table.Column<string>(nullable: true),
                    VariacaoCarteira = table.Column<string>(nullable: true),
                    Aceite = table.Column<string>(nullable: true),
                    CodigoInstrucao1 = table.Column<string>(nullable: true),
                    CodigoInstrucao2 = table.Column<string>(nullable: true),
                    DataDesconto = table.Column<DateTime>(nullable: true),
                    ValorDesconto = table.Column<decimal>(nullable: true),
                    DataMulta = table.Column<DateTime>(nullable: true),
                    PercentualMulta = table.Column<decimal>(nullable: true),
                    ValorMulta = table.Column<decimal>(nullable: true),
                    DataJuros = table.Column<DateTime>(nullable: true),
                    PercentualJurosDia = table.Column<decimal>(nullable: true),
                    ValorJurosDia = table.Column<decimal>(nullable: true),
                    CodigoProtesto = table.Column<int>(nullable: true),
                    DiasProtesto = table.Column<int>(nullable: true),
                    EnviarEmailSacado = table.Column<string>(nullable: true),
                    EnviarEmailCedente = table.Column<string>(nullable: true),
                    NumeroLote = table.Column<string>(nullable: true),
                    Reimpressao = table.Column<string>(nullable: true),
                    RecebimentoAntecipado = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Boleto", x => x.ID);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Boleto");
        }
    }
}
