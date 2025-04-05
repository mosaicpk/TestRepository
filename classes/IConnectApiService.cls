public interface IConnectApiService {
    Map<String, ConnectApiWrapper> getConnectApiCartItemDetails(String strWebStoreId, String strEffectiveAccountId, String strCartId);
}