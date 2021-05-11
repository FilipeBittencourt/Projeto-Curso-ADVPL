using Facile.BusinessPortal.Library.Security;
using Facile.BusinessPortal.Library.Structs.Post;
using Facile.BusinessPortal.Library.Structs.Return;
using Facile.BusinessPortal.StageArea.Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace Facile.BusinessPortal.StageArea.Interface
{
    public class ApiClient
    {
        protected readonly string baseUrl;
        protected string token;
        protected string client_key;
        protected string secret_key;

        public ApiClient(string _baseUrl, string _client_key, string _secret_key)
        {
            baseUrl = _baseUrl;
            client_key = _client_key;
            secret_key = _secret_key;
        }

        protected async Task GetTokenAsync(HttpClient client, ClientAuth auth)
        {
            try
            {
                //Todo: Verificar validade do Token
                if (!string.IsNullOrWhiteSpace(token))
                    return;

                var myContent = JsonConvert.SerializeObject(auth);
                var content = new StringContent(myContent);
                content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                var response = await client.PostAsync(baseUrl + @"access/authenticate", content);
                
                try
                {
                    var res = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                    var retPost = JsonConvert.DeserializeObject<AccessReturn>(res);
                    token = retPost.Token;
                }
                catch (Exception ex)
                {
                    throw;
                }
                finally
                {
                    response.Dispose();
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine("ERRO > GetTokenAsync: " + ex.Message);
                throw;
            }
        }

        public async Task<List<SaveDataReturn>> PostObjectListAsync(string method, object postObject)
        {
            try
            {
                HttpClientHandler clientHandler = new HttpClientHandler();
                clientHandler.ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => { return true; };

                using (var client = new HttpClient(clientHandler))
                {
                    client.BaseAddress = new Uri(baseUrl);

                    var auth = new ClientAuth() { Client_Key = client_key, Secret_Key = secret_key };
                    await GetTokenAsync(client, auth);

                    var myContent = JsonConvert.SerializeObject(postObject);

                    var uriPost = new Uri(client.BaseAddress, method);

                    var request = new HttpRequestMessage(HttpMethod.Post, uriPost);
                    request.Content = new StringContent(myContent);
                    request.Content.Headers.Clear();
                    request.Content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                    request.Headers.Clear();
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

                    var response = await client.SendAsync(request);
                    List<SaveDataReturn> retPost;
                    try
                    {
                        var res = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                        retPost = JsonConvert.DeserializeObject<List<SaveDataReturn>>(res);
                    }
                    catch (Exception ex)
                    {
                        throw;
                    }
                    finally
                    {
                        response.Dispose();
                    }
                   
                    return retPost;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("ERRO > PostObjectAsync: " + ex.Message);
                throw;
            }
        }

        public async Task<List<T>> GetObjectListAsync<T>(string method) where T : StructIntegracao
        {
            try
            {
                HttpClientHandler clientHandler = new HttpClientHandler();
                clientHandler.ServerCertificateCustomValidationCallback = (sender, cert, chain, sslPolicyErrors) => { return true; };

                using (var client = new HttpClient(clientHandler))
                {
                    client.BaseAddress = new Uri(baseUrl);

                    var auth = new ClientAuth() { Client_Key = client_key, Secret_Key = secret_key };
                    await GetTokenAsync(client, auth);

                    var uriPost = new Uri(client.BaseAddress, method);

                    var request = new HttpRequestMessage(HttpMethod.Get, uriPost);
                   // request.Content.Headers.Clear();
                    //request.Content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

                    request.Headers.Clear();
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

                    var response = await client.SendAsync(request);
                    List<T> retGet;

                    try
                    {
                        var res = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                        retGet = JsonConvert.DeserializeObject<List<T>>(res);
                    }
                    catch (Exception ex)
                    {
                        throw;
                    }
                    finally
                    {
                        response.Dispose();
                    }
                    return retGet;

                }
            }
            catch (Exception ex)
            {

                Console.WriteLine("ERRO > GetObjectAsync: " + ex.Message);
                throw;
            }
           
        }


    }
}
