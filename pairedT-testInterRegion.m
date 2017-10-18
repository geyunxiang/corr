%PAIRED T-TEST
rootpath = '' % root
preprocesses = {'FunImgRWS', 'FunImgRWSD', 'FunImgRWSDC', 'FunImgRWSDCF', 'FunImgRWSDglobalC', 'FunImgRWSDglobalCF'};
personNames = dir(preprocesses{1});
result = zeros(length(personNames), length(preprocesses)*2-2); % stores t stat and probability
for i in length(preprocesses)-1
	for j in 3:length(personNames)
		personName = personNames(j).name;
		net1 = load([preprocesses{i} '/' personName '/attrcsvs/inter-region-WholeCor.mat']);
		net1 = net1.WholeCor;
		net1Inter = tril(net1, -1);
		net1InterLong = reshape(net1Inter, prod(size(net1)), 1);
		net1InterLong = net1InterLong(net1InterLong ~= 0);
		net2 = load([preprocesses{i+1} '/' personName '/attrcsvs/inter-region-WholeCor.mat']);
		net2 = net2.WholeCor;
		net2Inter = tril(net2, -1);
		net2InterLong = reshape(net2Inter, prod(size(net2)), 1);
		net2InterLong = net2InterLong(net2InterLong ~= 0);
		[h, p, ci, stats] = ttest(net1InterLong, net2InterLong);
		result(j, 2*(i-1)+1) = p;
		result(j, 2*(i-1)+2) = stats,tstat;
	end
end
header = {'FunImgRWSp', 'FunImgRWSt', 'FunImgRWSDp', 'FunImgRWSDt', 'FunImgRWSDCp', 'FunImgRWSDCt', 'FunImgRWSDCFp', 'FunImgRWSDCFt', 'FunImgRWSDglobalCp', 'FunImgRWSDglobalCt'};
xzfn_write_matrix_to_csv('filename', header, result);